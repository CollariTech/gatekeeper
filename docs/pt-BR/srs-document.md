# Especificação de Requisitos de Software

## 1. Introdução

### 1.1 Propósito
Este documento especifica os requisitos do Gatekeeper, um sistema **CIAM** (Customer Identity and Access Management) moderno e modular. O Gatekeeper é projetado para gerenciar identidades, autenticação, autorização e experiências de acesso em ambientes multi-tenant, com foco em usuários finais externos, diferindo dos tradicionais sistemas de **IAM** voltados a funcionários internos.

### 1.2 Escopo
O sistema oferecerá uma infraestrutura robusta de **CIAM**, priorizando a segurança sem comprometer a performance. A plataforma dará suporte nativo a múltiplos métodos de autenticação (incluindo senhas, OTP, WebAuthn e login social), mecanismos avançados de autorização (RBAC, ABAC) e integração completa com o protocolo OAuth2 e OpenID Connect.

Diferente de soluções baseadas em **IDaaS** (Identity as a Service), o Gatekeeper será implementado como um serviço local e autocontido, evitando latências adicionais introduzidas por chamadas externas a serviços terceiros.

### 1.3 Referências

* **OAuth 2.0 – Especificações e Boas Práticas**
  * [The OAuth 2.0 Authorization Framework (RFC 6749)](https://www.rfc-editor.org/rfc/rfc6749.html)
  * [OAuth 2.0 Security Best Current Practice (RFC 9700)](https://www.rfc-editor.org/rfc/rfc9700.html)
  * [OAuth 2.0 Threat Model and Security Considerations (RFC 6819)](https://www.rfc-editor.org/rfc/rfc6819.html)
  * [OAuth 2.0 Pushed Authorization Requests (RFC 9126)](https://www.rfc-editor.org/rfc/rfc9126.html)
  * [OAuth 2.0 Rich Authorization Requests (RFC 9396)](https://www.rfc-editor.org/rfc/rfc9396.html)
* **OpenID Connect – Especificações e Boas Práticas**
  * [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html)
  * [OpenID Connect Discovery 1.0](https://openid.net/specs/openid-connect-discovery-1_0.html)
  * [OpenID Connect Federation 1.0](https://openid.net/specs/openid-connect-federation-1_0.html)
  * [OpenID Connect for Identity Assurance 1.0](https://openid.net/specs/openid-connect-4-identity-assurance-1_0.html)
* **SCIM – Gerenciamento de Identidade entre Domínios**
  * [SCIM Protocol (RFC 7644)](https://www.rfc-editor.org/rfc/rfc7644.html)
  * [SCIM Core Schema (RFC 7643)](https://www.rfc-editor.org/rfc/rfc7643.html)
* **WebAuthn (Autenticação na Web)**
  * [WebAuthn Level 2 – Especificação W3C (2025)](https://www.w3.org/TR/webauthn-3/)
  * [WebAuthn IANA Registry (RFC 8809)](https://www.rfc-editor.org/rfc/rfc8809.html)
* **OTP (One-Time Password)**
  * [TOTP: Time-Based One-Time Password Algorithm (RFC 6238)](https://www.rfc-editor.org/rfc/rfc6238.html)
* **Protocolo OPAQUE**
  * [The OPAQUE Augmented PAKE Protocol](https://datatracker.ietf.org/doc/draft-irtf-cfrg-opaque/)
* **Modelos de Autorização e Consentimento**
  * [Role-Based Access Control (ANSI INCITS 359-2012)](https://webstore.ansi.org/standards/incits/ansiincits3592012)
  * [NIST SP 800-162 – Guide to Attribute Based Access Control (ABAC)](https://csrc.nist.gov/publications/detail/sp/800-162/final)
  * [User-Managed Access (UMA) 2.0 – Kantara Initiative](https://docs.kantarainitiative.org/uma/rec-uma-core.html)
* **Segurança e Boas Práticas Adicionais**
  * [OWASP – OAuth 2.0 Protocol Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/OAuth2_Cheat_Sheet.html)
  * [OWASP Top Ten (2021)](https://owasp.org/Top10/)
  * [OWASP API Security Top Ten (2023)](https://owasp.org/www-project-api-security/)
* **Legislações de Proteção de Dados**
  * [LGPD – Lei Geral de Proteção de Dados (Brasil)](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
  * [GDPR – General Data Protection Regulation (EU)](https://eur-lex.europa.eu/eli/reg/2016/679/oj)
* **Normas Técnicas e Boas Práticas**
  * [NIST SP 800-53 Rev. 5 – Security and Privacy Controls](https://csrc.nist.gov/pubs/sp/800/53/r5)
  * [NIST SP 800-63B – Digital Identity Guidelines – Authentication](https://pages.nist.gov/800-63-3/sp800-63b.html)
  * [ISO/IEC 27001:2022 – Information Security Management](https://www.iso.org/standard/27001.html)
  * [ISO/IEC 27701:2019 – Privacy Information Management](https://www.iso.org/standard/71670.html)

---

## 2. Descrição Geral

### 2.1 Perspectiva do Produto
O Gatekeeper será desenvolvido como um serviço modular e isolado, voltado exclusivamente à gestão de identidade e acesso em contextos de alta escala. Sua arquitetura foi pensada para oferecer pontos de integração padronizados, expostos via interfaces como REST e gRPC, sem impor dependência de plataforma ou linguagem. Ele poderá ser implantado localmente (on-premises) ou embarcado em soluções maiores, atuando como um núcleo de autenticação e autorização interoperável.

### 2.2 Funcionalidades do Produto
* Autenticação baseada em senha
* Suporte a autenticação passwordless (magic link, WebAuthn)
* Suporte a autenticação adaptativa baseada em risco
* Autorização com suporte a RBAC, ABAC e delegação de acesso (OAuth2)
* Verificação multi-fator (MFA) com TOTP
* Gerenciamento de identidades e provisionamento via SCIM 2.0
* Federação de identidade com OpenID Connect e descoberta dinâmica
* Isolamento multi-tenant com suporte a múltiplos projetos
* Gerenciamento de sessões baseada em dispositivos
* Registro e controle de consentimento conforme LGPD/GDPR
* Auditoria de eventos de segurança e acessos sensíveis
* Administração de usuários, permissões e configurações por projeto
* Conformidade com normas como NIST 800-63B, ISO/IEC 27001 e 27701

### 2.3 Classes e Características dos Usuários

| Classe de Usuário                | Descrição                                                                   | Acessos e Responsabilidades Principais                                             |
|----------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------|
| **Usuários Finais**              | Indivíduos externos que utilizam os serviços das aplicações integradas      | Autenticação, recuperação de conta, gestão de perfil, consentimento de acesso      |
| **Desenvolvedores**              | Técnicos que integram suas aplicações ao Gatekeeper                         | Registro de clientes, configuração de fluxos OAuth2/OIDC, consumo de APIs          |
| **Sistemas Terceiros (Clients)** | Aplicações confiáveis que solicitam autenticação/autorização                | Requisição de tokens, autenticação federada, acesso a recursos protegidos          |

### 2.4 Restrições de Design e Implementação
* O sistema deverá adotar a arquitetura hexagonal (ports and adapters), visando isolamento de lógica de domínio, testabilidade e flexibilidade na troca de tecnologias externas.
* Toda comunicação deverá ocorrer exclusivamente sobre canais seguros (TLS 1.2+ obrigatório). Para ações sensíveis, essas deverão ocorrer por meio do gRPC.
* O sistema não armazenará sessões em banco relacional ou distribuído, devendo manter os tokens em memória ou mecanismos externos compatíveis (ex.: Redis).
* As interfaces públicas (REST/gRPC) deverão respeitar versionamento e autenticação forte (ex.: mTLS, OAuth2 Client Credentials).
* A interface WebAuthn só deverá ser exposta em navegadores que suportem WebCrypto API.
* Não será oferecido suporte a dispositivos legados sem HTTPS ou sem suporte mínimo a operações criptográficas modernas.

### 2.5 Premissas e Dependências
* Assume-se que os consumidores do Gatekeeper implementarão corretamente o fluxo de autenticação OAuth2/OpenID Connect.
* Usuários finais utilizarão navegadores ou dispositivos compatíveis com os padrões modernos de autenticação (TOTP, WebAuthn, etc.).
* A sincronização de tempo entre cliente e servidor é fundamental para o funcionamento correto de TOTP.
* O serviço de e-mail e SMS usado para MFA e recuperação de conta será fornecido externamente e deverá estar operacional.
* A camada de rede entre os componentes do sistema e os sistemas consumidores será confiável, com baixa latência e alta disponibilidade.

---

## 3. Requisitos de Interface Externa
### 3.1 Interfaces de Software
### 3.2 Interfaces de Comunicação
### 3.3 Interfaces de Identidade Externa

---

## 4. Funcionalidades do Sistema

---

## 5. Requisitos Não Funcionais
### 5.1 Segurança
### 5.2 Desempenho
### 5.3 Disponibilidade
### 5.4 Escalabilidade
### 5.5 Observabilidade
### 5.6 Conformidade

---

## 6. Outros Requisitos
### 6.1 Processo de Rotação de Chaves
### 6.2 Estratégias de Mitigação de Ataques
### 6.3 Auditoria e Conformidade

---

## 7. Apêndices
### 7.1 Glossário
### 7.2 Cenários de Uso / Casos de Uso
### 7.3 Modelos de Domínio
#### Modelo de Usuário
#### Modelo de Aplicação Cliente
#### Modelo de Sessão/Token
### 7.4 Diagramas e Fluxos
#### 7.4.1 Fluxo OPAQUE
#### 7.4.2 Registro WebAuthn
#### 7.4.3 Fluxo OAuth2 com PKCE
#### 7.4.4 Renovação de Token
#### 7.4.6 Fluxo de Autenticação via Provedores Externos
