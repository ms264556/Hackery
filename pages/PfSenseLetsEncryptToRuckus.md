# Get pfSense to push Let's Encrypt Certificates to your Ruckus ZoneDirector or Unleashed AP.

There's no official API for the Ruckus ZoneDirector or Ruckus Unleashed. And the CLI doesn't provide a way to upload HTTPS certificates.

This is a pain. Certificates issued by letsencrypt.org are only good for 90 days, so automation is key.

If you've got the Acme service setup in pfSense then you can push Let's Encrypt certificates onto your ZoneDirector/Unleashed whenever they come in.
This will reboot the target ZoneDirector/Unleashed, but the Acme service runs at 3:16am so probably no big issue.
> Be aware that older Unleashed APs (e.g. R500 or R600) may take 10 minutes to reboot completely.


### Create the Script

* Use `Diagnostics` / `Edit File` to create a new file `/usr/local/bin/export_zd_cert.sh` :-

```sh
ZD_USERNAME='ruckususer'
ZD_PASSWORD='ruckuspassword'

ZD_CERTIFICATE=$1
ZD_FQDN=$2

ZD_COOKIE="/tmp/zonedirectorlogincookie.txt"

cd /conf/acme

ZD_LOGIN_URL="$(curl https://$ZD_FQDN -k -s -L -I -o /dev/null -w '%{url_effective}')"
LOGIN_ARGS="-k -c $ZD_COOKIE"
ZD_XSS="$(curl $LOGIN_ARGS $ZD_LOGIN_URL -d username=$ZD_USERNAME -d password=$ZD_PASSWORD -d ok=Log\ In -i | awk '/^HTTP_X_CSRF_TOKEN:/ { print $2 }' | tr -d '\040\011\012\015')"

ZD_BASE_URL="$(dirname $ZD_LOGIN_URL)"
CONF_ARGS="-i -k -b $ZD_COOKIE -c $ZD_COOKIE"
ZD_UPLOAD="$CONF_ARGS $ZD_BASE_URL/_upload.jsp?request_type=xhr"
ZD_CMD="$CONF_ARGS $ZD_BASE_URL/_cmdstat.jsp"

REPLACE_CERT_AJAX="<ajax-request action=\"docmd\" comp=\"system\" updater=\"rid.0.5\" xcmd=\"replace-cert\" checkAbility=\"6\" timeout=\"-1\"><xcmd cmd=\"replace-cert\" cn=\"$ZD_FQDN\"/></ajax-request>"
CERT_REBOOT_AJAX="<ajax-request action=\"docmd\" comp=\"worker\" updater=\"rid.0.5\" xcmd=\"cert-reboot\" checkAbility=\"6\"><xcmd cmd=\"cert-reboot\" action=\"undefined\"/></ajax-request>"

curl $ZD_UPLOAD -H "X-CSRF-Token: $ZD_XSS" -F u=@$ZD_CERTIFICATE.crt -F action=uploadcert -F callback=uploader_uploadcert
curl $ZD_UPLOAD -H "X-CSRF-Token: $ZD_XSS" -F u=@$ZD_CERTIFICATE.key -F action=uploadprivatekey -F callback=uploader_uploadprivatekey
curl $ZD_CMD -H "X-CSRF-Token: $ZD_XSS" --data-raw "$REPLACE_CERT_AJAX"
curl $ZD_CMD -H "X-CSRF-Token: $ZD_XSS" --data-raw "$CERT_REBOOT_AJAX"
```

### Ask the Acme Service to run the script after renewing your certificate

* In `Services` / `Acme Certificates` / `General settings`, make sure the `Write Certificates` box is ticked.
* In `Services` / `Acme Certificates` / `Certificates`, edit the certificate you want to use on your Ruckus ZoneDirector/Unleashed. Add a `Shell Command` to the `Actions List`: `/usr/local/bin/export_zd_cert.sh name.of.this.certificate zdhost.your.domain.name` .
* Check that the `Private Key` setting for your certificate is RSA (ECDSA is unsupported on Unleashed and ZoneDirector).
> `zdhost.your.domain.name` is whatever fully qualified hostname you're using for your ZoneDirector/Unleashed, and `name.of.this.certificate` is what you entered in the `Name` box for this certificate.

### (Optionally) Add a DNS Host Override

The script expects to be able to find your ZoneDirector/Unleashed at the specified fully qualified domain name.

If your `Domain` in `System` / `General Setup` is different from the the domain in your certificate (e.g. your certitificate is for `*.your.domain.name` but your pfSense domain is `localdomain`), then you might need pfSense to return an internal IP for `zdhost.your.domain.name`.
* Go to `Services` / `DNS Resolver`, and `Add` a `Host Override`.
