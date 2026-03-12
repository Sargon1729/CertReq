# CertReq
Painless way to request certs from windows ADCS

This script uses the folder names as the source of information for which template you wish to use, simply place the csr in the folder, and provided it matches a template, it will be signed using that template

For this to work you need to create a folder structure like the below

```plaintext
.
└── PKIROOT/
    ├── completed_csr
    ├── signed_certs
    ├── CSR - <Cert template name>
    ├── CSR - <Cert template name>
    ├── CSR - <Cert template name>
    └── CSR - <Cert template name>
```

In order to get the correct name for the templates (as they are not just the same as they apperar in the GUI) use ` certutil -catemplates | foreach { $_.split(": ")[0]}`