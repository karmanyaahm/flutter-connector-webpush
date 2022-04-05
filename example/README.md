# flutter-example

Demonstrates how to use the unifiedpush flutter-connector-webpush plugin for Flutter.

You can test this in python using `pywebpush`. Endpoint, pubkey, and auth are printed in the example app's logs.
```python
from pywebpush import webpush
webpush({"endpoint": "<endpoint>", "keys": {"p256dh": "<pubkey>", "auth":"<authKey>"}}, "title=title&message=me")
```


