# **Guacamole 1.5.3 VDI/Jump Server Appliance Build Script**

Um script de construção e instalação de origem baseado em menu para Guacamole 1.5.3 com proxy reverso TLS opcional, integração AD, autenticação multifator, maior reforço de segurança e suporte ao modo escuro.

### **Script automático de construção, instalação e configuração**

Para construir o dispositivo Guacamole, cole o link abaixo em um terminal e siga as instruções **(não execute como sudo)**:

```
wget https://raw.githubusercontent.com/itiligent/Guacamole-Install/main/1-setup.sh && chmod +x 1-setup.sh && ./1-setup.sh
```

## **Pré-requisitos**
### NOTA: DEBIAN 12 E TOMCAT 10 NÃO ATUALMENTE COMPATÍVEIS - VEJA A EDIÇÃO #10

- **Ubuntu 18.04 - 22.x / Debian 11 e 10 / Raspbian Buster ou Bullseye**
- *(se estiver usando imagens de nuvem de fornecedores de sistema operacional - você deve usar **versões estáveis das variantes de sistema operacional acima.** As compilações diárias de imagens de nuvem são semelhantes a versões contínuas e podem conter atualizações ainda não suportadas que quebram o Guacamole!)*
- Mínimo de 8 GB de RAM e 40 GB de HDD
- Entradas DNS públicas ou privadas que correspondem ao endereço IP da interface de rota padrão (obrigatório para TLS)
- Acesso de entrada nas portas TCP 22, 80 e 443
- Não execute como root. O usuário que executa o script do instalador deve ser um **membro do grupo sudo**

## **Fluxo do menu do instalador**

### **1. Confirme o nome do host do sistema e o sufixo do domínio DNS local**

### **2. Selecione um tipo de instância MySQL e uma linha de base de segurança**

- Instalar uma nova instância local do MySQL ou escolher uma instância existente/remota do MySQL?
- *Opcionalmente, adicione configurações do MySQL **mysql_secure_installation** à instância do MySQL selecionada*
- *Opcionalmente, forneça um endereço de e-mail para mensagens de backup e alertas*

### **3. Escolha uma extensão de autenticação**

- DUO, TOTP, LDAP ou nenhum?

### **4. Escolha a frente do Guacamole**

- **Instalar proxy reverso Nginx?** [s/n]
- Não: mantém o front-end e URL nativos do Guacamole http://server.local:8080/guacamole
- Sim: solicita um nome DNS local do proxy reverso (pode ser diferente do nome do host)
   
- **Instalar proxy reverso Nginx com um certificado TLS autoassinado?** [s/n]
- Não: instala o Nginx como proxy reverso **http**, site Guacamole definido como http://server.local
- Sim: instala o Nginx como proxy reverso **https**, site Guacamole definido como https://server.local
- *Nginx está configurado com um certificado TLS autoassinado e redirecionamento http*
- *Certificados de navegador cliente autoassinados para Windows e Linux gerados*

- **Instalar o proxy reverso Nginx com um certificado Let's Encrypt?** [s/n]
- Sim: solicita um e-mail do webmaster e um nome DNS do proxy reverso público
- *Instala o Nginx como proxy reverso **https**, site Guacamole definido como* https://your-public-site.com
- *Nginx configurado com um novo certificado LetsEncrypt e redirecionamento http*
- *Renovações contínuas de certificados certbot agendadas*

## **Opções de proteção pós-instalação**

O instalador baixa adicionalmente os seguintes scripts de configuração manual:
- `add-fail2ban.sh` - Adiciona uma política de bloqueio fail2ban de linha de base ao Guacamole (e coloca a sub-rede local na lista de permissões)
- `add-tls-guac-daemon.sh` - Adiciona um wrapper TLS ao tráfego interno entre o aplicativo Guacamole e o daemon do servidor guacd
- `add-auth-ldap.sh` - Um script de modelo para integração do Guacamole com o Active Directory
- `add-smtp-relay-o365.sh` - Um script de modelo para alertas por e-mail via MSO65 (autenticação SMTP via senha do aplicativo BYO)

## **Integração com o Active Directory**

Consulte as instruções de autenticação do Active Directory [aqui](https://github.com/itiligent/Guacamole-Install/blob/main/ACTIVE-DIRECTORY-HOW-TO.md)


## **Notas de instalação**

O instalador pode ser executado interativamente ou para uma configuração personalizada/autônoma:
1. Em uma sessão de terminal, mude para seu diretório inicial, cole e execute o link wget autorun acima.
2. Saia do script `1-setup.sh` no primeiro prompt. (Neste ponto, apenas os scripts foram baixados).
3. Personalize as diversas variáveis de instalação na seção "Opções de configuração silenciosa" de `1-setup.sh` conforme apropriado.
- *Variáveis de script com um determinado valor (por exemplo, `VARIABLE="value"`) não serão solicitadas durante a configuração interativa. Com a combinação certa de variáveis de script personalizadas, é possível implantar dispositivos Guacamole sem toque em apenas alguns minutos.*
4. **Cuidado: Se alguma configuração em `1-setup.sh` for editada, você deverá executar este script modificado localmente. Se você executar o link de execução automática do wget novamente, você substituirá todas as suas alterações!**
- *Todas as opções de instalação são gerenciadas em `1-setup.sh`. Se você editar qualquer um dos outros scripts baixados, **você também deve comentar o link de download correspondente de cada script** na seção "Baixar configuração do GitHub" de `1-setup.sh` para evitar novo download e substituição ao executar a configuração .*
- *Alguns scripts manuais são personalizados automaticamente na instalação para refletir várias configurações e opções de instalação.*
6. Se a opção TLS autoassinado for selecionada, os certificados TLS do cliente serão salvos em `$DOWNLOAD_DIR/guac-setup`.
7. O Nginx está configurado para suportar apenas TLS 1.2 ou superior.

## **Baixar manifesto**

O link de execução automática acima baixa os seguintes itens no diretório `$DOWNLOAD_DIR/guac-setup`:

- `1-setup.sh`: O próprio script de instalação pai (salvo no diretório atual)
- `2-install-guacamole.sh`: script de instalação do Guacamole (baseado em [MysticRyuujin/guac-install](https://github.com/MysticRyuujin/guac-install))
- `3-install-nginx.sh`: instala o Nginx e configura automaticamente um proxy reverso front-end para Guacamole (opcional)
- `4a-install-tls-self-signed-nginx.sh`: Configura certificado TLS autoassinado para proxy Nginx (opcional)
- `4b-install-tls-letsencrypt-nginx.sh`: Instala e configura Let's Encrypt para proxy Nginx (opcional)
- `add-auth-duo.sh`: Adiciona a extensão Duo MFA se não for selecionada durante a instalação (opcional)
- `add-auth-ldap.sh`: Adiciona a extensão do Active Directory e o modelo de configuração se não for selecionado na instalação (opcional)
- `add-auth-totp.sh`: Adiciona a extensão TOTP MFA se não for selecionada na instalação (opcional)
- `add-tls-guac-daemon.sh`: Um script de proteção para adicionar um wrapper TLS entre o daemon do servidor guacd e o tráfego do aplicativo Guacamole (opcional, considere mitigações extras de impacto no desempenho)
- `add-fail2ban.sh`: Adiciona uma política fail2ban (com substituição de sub-rede local) para proteger o Guacamole contra ataques externos de força bruta
- `add-smtp-relay-o365.sh`: configura um relé de autenticação SMTP com O365 para monitoramento e alertas (senha do aplicativo BYO)
- `backup-guacamole.sh`: Um script simples de backup MySQL Guacamole
- `branding.jar`: Um modelo de exemplo para um tema Guacamole personalizado (modo escuro!). Exclua este arquivo para manter a IU padrão do Guacamole. A fonte desta extensão também está incluída para facilitar o estudo e a personalização.
