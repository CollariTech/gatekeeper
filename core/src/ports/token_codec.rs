use serde::{Deserialize, Serialize};

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
}

pub trait TokenCodec {
    fn generate<T: Serialize>(&self, payload: &T, auth_version: u32) -> Result<String, TokenError>;

    fn validate<T: for<'de> Deserialize<'de>>(
        &self,
        token: &str,
        auth_version: u32,
    ) -> Result<T, TokenError>;
}
