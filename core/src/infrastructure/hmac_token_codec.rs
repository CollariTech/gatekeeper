use hmac::Hmac;
use sha2::Sha256;

use crate::ports::token_codec::{TokenCodec, TokenError};

pub struct HmacTokenCodec {
    hmac_key: Hmac<Sha256>,
}

impl TokenCodec for HmacTokenCodec {
    fn generate<T: serde::Serialize>(
        &self,
        payload: &T,
        auth_version: u32,
    ) -> Result<String, TokenError> {
        std::todo!()
    }

    fn validate<T: for<'de> serde::Deserialize<'de>>(
        &self,
        token: &str,
        auth_version: u32,
    ) -> Result<T, TokenError> {
        std::todo!()
    }
}

#[cfg(test)]
mod test {}
