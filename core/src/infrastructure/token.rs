use base64::Engine;
use base64::prelude::BASE64_STANDARD;
use bincode::Encode;
use hmac::{Hmac, Mac};
use sha2::Sha256;

#[derive(Debug, thiserror::Error)]
pub enum TokenError {
    #[error("Failed to serialize payload: {0}")]
    SerializationError(String),
    #[error("Failed to deserialize payload: {0}")]
    DeserializationError(String),
    #[error("Invalid token format")]
    InvalidTokenFormat,
    #[error("Token validation failed")]
    ValidationFailed,
    #[error("Token has expired")]
    TokenExpired,
    #[error("Crypto operation failed: {0}")]
    CryptoError(String),
    #[error("Base64 operation failed: {0}")]
    Base64Error(String),
    #[error("Invalid token signature")]
    InvalidSignature,
}

pub struct TokenCodec {
    secret: Vec<u8>
}

impl TokenCodec {
    pub fn new(secret: Vec<u8>) -> Self {
        TokenCodec {
            secret
        }
    }

    fn generate<T: Encode>(&self, payload: &T, auth_version: u8) -> Result<String, TokenError> {
        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|_| TokenError::CryptoError("Failed to get current time".to_string()))?
            .as_millis() as u64;

        let timestamp_bytes = timestamp.to_le_bytes();

        let mut payload_bytes = Vec::new();
        let _bytes_written = bincode::encode_into_slice(payload, &mut payload_bytes, bincode::config::standard())
            .map_err(|e| TokenError::SerializationError(e.to_string()))?;

        let mut data = Vec::new();
        data.extend_from_slice(&timestamp_bytes);
        data.extend_from_slice(&payload_bytes);

        let hmac_signature = self.generate_hmac(auth_version, &data)
            .map_err(|e| TokenError::CryptoError(e.to_string()))?;

        let mut token_bytes = Vec::new();
        token_bytes.extend_from_slice(&data);
        token_bytes.extend_from_slice(&hmac_signature);

        let token = BASE64_STANDARD.encode(&token_bytes);
        Ok(token)
    }

    fn validate<T: bincode::de::Decode<()>>(
        &self,
        token: &str,
        auth_version: u8,
    ) -> Result<T, TokenError> {
        let token_bytes = BASE64_STANDARD
            .decode(token)
            .map_err(|e| TokenError::Base64Error(e.to_string()))?;

        if token_bytes.len() < 8 + 32 {
            return Err(TokenError::InvalidTokenFormat);
        }

        let timestamp_bytes = &token_bytes[0..8];
        let payload_and_hmac = &token_bytes[8..];
        let hmac_offset = payload_and_hmac.len() - 32;
        let payload_bytes = &payload_and_hmac[..hmac_offset];
        let received_hmac = &payload_and_hmac[hmac_offset..];

        let data = &token_bytes[..hmac_offset + 8];
        let expected_hmac = self.generate_hmac(auth_version, data)?;
        if expected_hmac != received_hmac {
            return Err(TokenError::InvalidSignature);
        }

        let (payload, _bytes_read) = bincode::decode_from_slice::<T, _>(payload_bytes, bincode::config::standard())
            .map_err(|e| TokenError::SerializationError(e.to_string()))?;

        Ok(payload)
    }

    fn generate_hmac(&self, auth_version: u8, data: &[u8]) -> Result<Vec<u8>, TokenError> {
        let mut hmac = self.derive_hmac_key(auth_version)
            .map_err(|e| TokenError::CryptoError(e.to_string()))?;
        hmac.update(data);
        Ok(hmac.finalize().into_bytes().to_vec())
    }

    fn derive_hmac_key(&self, auth_version: u8) -> Result<Hmac<Sha256>, TokenError> {
        let mut final_secret = auth_version.to_le_bytes().to_vec();
        final_secret.extend_from_slice(&self.secret);
        Hmac::<Sha256>::new_from_slice(&final_secret)
            .map_err(|e| TokenError::CryptoError(e.to_string()))
    }
}
