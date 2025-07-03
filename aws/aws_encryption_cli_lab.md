
# AWS Encryption CLI Lab

## 📌 Lab Goal
Encrypt a file using the AWS Encryption CLI with a specified AWS KMS key.

---

## 🛠️ Prerequisites

- AWS CLI installed and configured properly.
- `aws-encryption-cli` installed.
- A valid KMS Key ARN.
- A file to encrypt (e.g., `secret1.txt`).
- Valid AWS credentials with session token (for temporary credentials).

---

## ✅ Step-by-Step Instructions

### 1. Create a directory structure
```bash
mkdir ~/output
```

### 2. Set your KMS Key ARN in a variable
```bash
keyArn="arn:aws:kms:us-west-2:YOUR-ACCOUNT-ID:key/YOUR-KEY-ID"
```

### 3. Encrypt the file using `aws-encryption-cli`
```bash
aws-encryption-cli --encrypt \
                     --input secret1.txt \
                     --wrapping-keys key=$keyArn \
                     --metadata-output ~/metadata \
                     --encryption-context purpose=test \
                     --commitment-policy require-encrypt-require-decrypt \
                     --output ~/output/.
```

⚠️ If you see an error like:
```
GenerateKeyError("Master Key ... unable to generate data key")
```
It usually means your AWS credentials are invalid.

---

## 🔐 Fix AWS Credentials Error

You might see:
```
An error occurred (UnrecognizedClientException) when calling the GenerateDataKey operation: The security token included in the request is invalid.
```

To fix this:

### 4. Set up temporary credentials
Edit `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
aws_session_token = YOUR_SESSION_TOKEN
```

> Make sure to replace the placeholders with the actual values from your temporary session credentials.

---

## ✅ Final Test

Try encrypting again after fixing credentials:
```bash
aws-encryption-cli --decrypt \
                     --input secret1.txt.encrypted \
                     --wrapping-keys key=$keyArn \
                     --commitment-policy require-encrypt-require-decrypt \
                     --encryption-context purpose=test \
                     --metadata-output ~/metadata \
                     --max-encrypted-data-keys 1 \
                     --buffer \
                     --output .
```

You should find the encrypted file in the `~/output/` directory as `secret1.txt.encrypted`.

---

## 📂 Output Example

```
~/output/
├── secret1.txt.encrypted
```

---

## 🧠 Notes

- Always verify your credentials and region match the key's location.
- Use `--verbosity` flag if you need more debug information.
