# Authenticity and Liability

## Anti-Impersonation Measures

This skill includes several mechanisms to prevent impersonation and ensure authenticity:

1. **Cryptographic Signatures**: All official releases are signed with GPG and verified via Cosign.
2. **Verified Publisher**: The skill is published by the original btcrecover maintainer (3rdIteration).
3. **Immutable Safety Rules**: The safety-rules.md file is read every session and cannot be bypassed by user prompts.
4. **Skill Provenance**: The skill checks its own source and warns if loaded from an untrusted location.
5. **Official Distribution**: Users are advised to obtain the skill only from the official GitHub repository or verified mirrors.

## Liability Protection

### Disclaimer of Warranty
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### User Responsibilities
- The user assumes all risk associated with wallet recovery efforts.
- The user is responsible for verifying the integrity of any tools used (btcrecover, etc.).
- The user must follow the post-recovery safety protocol (sweeping funds to a new wallet).
- The user must keep their recovery process confidential and secure.

### Scope of Assistance
This skill provides guidance and automation for the btcrecover tool. It does not:
- Guarantee successful recovery of any wallet.
- Access or transmit wallet data without explicit user approval.
- Replace the need for proper wallet security practices.
- Provide legal or financial advice.

### Reporting Issues
If you discover a security vulnerability or have concerns about the skill's authenticity, please contact the maintainer through the official GitHub repository issues page.

---
*Last updated: May 2026*