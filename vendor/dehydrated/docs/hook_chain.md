# HOOK_CHAIN

If you want to deploy (and clean) all challenges for a single certificate in one hook call you can use `HOOK_CHAIN=yes` in your config.

Calls to your hook script change in a way that instead of having only X parameters on deploy_challenge and clean_challenge it will have Y*X parameters,
where Y is the number of domains in your cert, and you'll have to iterate over a set of X parameters at a time in your hook script.

See below for an example on how the calls change:

### HOOK_CHAIN="no" (default behaviour)
```
# INFO: Using main config file /etc/dehydrated/config
Processing lukas.im with alternative names: www.lukas.im
 + Checking domain name(s) of existing cert... unchanged.
 + Checking expire date of existing cert...
 + Valid till Jul  7 20:54:00 2016 GMT (Longer than 30 days). Ignoring because renew was forced!
 + Signing domains...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for lukas.im...
 + Requesting challenge for www.lukas.im...
HOOK: deploy_challenge lukas.im blablabla blablabla.supersecure
 + Responding to challenge for lukas.im...
HOOK: clean_challenge lukas.im blablabla blablabla.supersecure
 + Challenge is valid!
HOOK: deploy_challenge www.lukas.im blublublu blublublu.supersecure
 + Responding to challenge for www.lukas.im...
HOOK: clean_challenge www.lukas.im blublublu blublublu.supersecure
 + Challenge is valid!
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
HOOK: deploy_cert lukas.im /etc/dehydrated/certs/lukas.im/privkey.pem /etc/dehydrated/certs/lukas.im/cert.pem /etc/dehydrated/certs/lukas.im/fullchain.pem /etc/dehydrated/certs/lukas.im/chain.pem 1460152442
 + Done!
```

### HOOK_CHAIN="yes"
```
# INFO: Using main config file /etc/dehydrated/config
Processing lukas.im with alternative names: www.lukas.im
 + Checking domain name(s) of existing cert... unchanged.
 + Checking expire date of existing cert...
 + Valid till Jul  7 20:52:00 2016 GMT (Longer than 30 days). Ignoring because renew was forced!
 + Signing domains...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for lukas.im...
 + Requesting challenge for www.lukas.im...
HOOK: deploy_challenge lukas.im blablabla blablabla.supersecure www.lukas.im blublublu blublublu.supersecure
 + Responding to challenge for lukas.im...
 + Challenge is valid!
 + Responding to challenge for www.lukas.im...
 + Challenge is valid!
HOOK: clean_challenge lukas.im blablabla blablabla.supersecure www.lukas.im blublublu blublublu.supersecure
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
HOOK: deploy_cert lukas.im /etc/dehydrated/certs/lukas.im/privkey.pem /etc/dehydrated/certs/lukas.im/cert.pem /etc/dehydrated/certs/lukas.im/fullchain.pem /etc/dehydrated/certs/lukas.im/chain.pem 1460152408
 + Done!
```