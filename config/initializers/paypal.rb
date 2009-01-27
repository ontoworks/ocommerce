# TODO cambiar por datos printer depot
$paypal_user = "theprinterdepot_api1.yahoo.com"
$paypal_password = "DATR6S6HLFGN6VQX"
$paypal_signature = "AhlOYnmYhN9CSX1pA"
require 'paypal'

Paypal::Notification.ipn_url = 'https://www.paypal.com/cgi-bin/webscr'

