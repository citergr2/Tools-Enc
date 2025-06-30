#!/bin/bash
read -sp "Password: " pwd
echo ""
openssl enc -aes-256-cbc -d -in XitersToolsEnc.enc -pass pass:$pwd | bash
