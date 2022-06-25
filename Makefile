initsh:
	# this doesn't actually work, because makefile doesn't send env vars out, but use this as a reference
	export CHROME_EXECUTABLE=/usr/bin/chromium
totest:
	# again, don't actually run this using the makefile, it needs env vars copied from the app's logs. run export <env vars copied from logs>
	sleep 2 && npx web-push send-notification --vapid-pubkey=`jq .publicKey myvapid -rc` --vapid-pvtkey=`jq .privateKey myvapid -rc` --vapid-subject=https://karmanyaah.malhotra.cc/contact/ --endpoint=$ENDPOINT --key=$P256DH  --auth=$AUTHKEY --payload='message=Hellotestttt&title=abcd'
genvapidkeys:
	# you CAN run this using the makefile, but use the commited credentials because the app has them embedded
	web-push generate-vapid-keys --json > myvapid
