# Nihaopay Ruby

[![Build Status](https://travis-ci.org/kkvesper/nihaopay-ruby.svg?branch=master)](https://travis-ci.org/kkvesper/nihaopay-ruby)

Nihaopay Ruby is a Ruby wrapper for using the [Nihaopay](https://www.nihaopay.com) payment gateway API.

This library is provided by [KK VESPER](https://www.kkvesper.jp/) and is not affiliated
with or supported by [Aurfy Inc](https://www.nihaopay.com), makers of Nihaopay.


## Installation

Add the following to your Gemfile:

`gem 'nihaopay-ruby'`

and run `bundle install`

#### Configuration

Add a file *config/initializers/nihaopay.rb*.

``` ruby
Nihaopay.configure do |nihaopay|
  nihaopay.test_mode = true
  nihaopay.token = <your-merchant-token>
  nihaopay.currency = 'USD'
end
```

The default value for `test_mode` is `false`. Default `currency` is `'USD'`.


## Initiate a SecurePay transaction

#### UnionPay

```ruby
options = { reference: '3461fcc31aec471780ad1a4dc6111947',
            ipn_url: 'http://website.com/ipn',
            callback_url: 'http://website.com/callback' }
response = Nihaopay::SecurePay::UnionPay.start(amount, currency, options)
render inline: "<%= response.body %>"
```

`amount` should be an integer of the minor unit in the currency, e.g. $10.50 in USD would be 1050.

`currency` can be `'USD'` and `'JPY'`.

**Options:**

- `reference` is an alphanumeric string up to 30 characters that must be unique to each of your transactions.
- `ipn_url` is Instant Payment Notification URL called by the API to update you on the transaction information.
- `callback_url` is the URL the browser will be redirected to upon completing the transaction.
- `description` (optional)
- `note` (optional)
- `terminal` (optional) specifies whether payment is submitted on desktop (*ONLINE*) or mobile (*WAP*). Currently, acceptable values are *ONLINE* and *WAP*. Please note *WAP* for WeChat Pay is only available in live environment.
- `timeout` (optional) specifies amount of minutes card holders have before payment page times out. Once the page times out without a successful payment, the transaction is automatically cancelled. Acceptable values are *1 - 1440*.

Due to the nature of redirects and users being able to close their browsers before the redirect can happen, an instant payment notification (IPN) URL is used to provide transaction data.

Whenever possible, transaction data should be recorded from the IPN URL instead of the callback URL.

Sample Credit Card details for UnionPay are:

- Number: 6221 5588 1234 0000
- Expiry year: 17
- Expiry month: 11
- Last 3 digits: 123
- Phone: 1-355-253-5506
- Sms verification: 111111

**Override global token**

```ruby
merchant = Nihaopay::Merchant.new(token)
response = merchant.union_pay(amount, currency, options)
```

#### AliPay

You can use the same `options` from *UnionPay* for *AliPay* transactions.

```ruby
response = Nihaopay::SecurePay::AliPay.start(amount, currency, options)
```

Sample account details for AliPay are:
- Number: 13122443313
- Login password: 111111
- Payment password: 111111

**Override global token**

```ruby
merchant = Nihaopay::Merchant.new(token)
response = merchant.ali_pay(amount, currency, options)
```

#### WeChatPay

You can use the same `options` from *UnionPay* for *WeChatPay* transactions.

```ruby
response = Nihaopay::SecurePay::WeChatPay.start(amount, currency, options)
```

For WeChatPay, you will see a QR code on the vendor payment page. Scan the code from WeChat mobile app and complete the payment. It will automatically redirect to Callback URL upon payment completion.

**Override global token**

```ruby
merchant = Nihaopay::Merchant.new(token)
response = merchant.wechat_pay(amount, currency, options)
```


## ExpressPay

#### Authorize transaction on ExpressPay

You need the credit card details for initiating the transaction. You can build the credit card object as below:

``` ruby
credit_card = Nihaopay::CreditCard.new(
                number: '6221558812340000',
                expiry_year: 2017,
                expiry_month: 11,
                cvv: '123')
```

Acceptable values for `expiry_month` are `01` through `12`.

Now initiate the transaction using above credit card.

``` ruby
express_pay = Nihaopay::Transactions::Authorize.start(amount, credit_card)
```

This returns an instance of `Nihaopay::Transactions::ExpressPay` on which you can access following methods:

``` ruby
express_pay.transaction_id   # => "20160714132438002485"
express_pay.status           # => "success"
express_pay.reference        # => "3461fcc31aec471780ad1a4dc6111947"
express_pay.currency         # => "JPY"
express_pay.amount           # => 1000
express_pay.captured         # => false
express_pay.time             # => 2017-01-18 12:08:42 +0900
```

Other methods available are `note` and `time`.

#### Purchase transaction on ExpressPay

``` ruby
express_pay = Nihaopay::Transactions::Purchase.start(amount, credit_card)
```

This again returns an instance of `Nihaopay::Transactions::ExpressPay`.

#### Options for ExpressPay transactions

For `authorize` and `purchase`, you can pass `currency`, `description`, `note`, and `reference` as options.

``` ruby
express_pay = Nihaopay::Transactions::Authorize.start(amount, credit_card, { currency: 'USD',
                                                                             description: 'Your order description',
                                                                             note: 'Something to remember',
                                                                             reference: 'A unique alphanumeric string',
                                                                             merchant_id: 'unique ID for nihaopay merchant' })
```

Acceptable currency codes are 'USD' and 'JPY'.

The option `merchant_id` will be passed as `{ reserved: { 'sub_mid' => merchant_id } }` in the params. All the different types of ExpressPay transactions accept this option.

#### Capture a transaction

``` ruby
captured = express_pay.capture
captured.transaction_id           # => "20160718111604002633"
captured.status                   # => "success"
captured.captured                 # => true
captured.capture_transaction_id   # => "20160718111529002632" (id of the transaction that was captured)
captured.time                     # => 2017-01-18 12:08:42 +0900
```

If you want to capture a partial amount, you can do:

``` ruby
captured = express_pay.partial_capture(amount)
```

Authorizations not captured within 30 days are automatically released and cannot be captured.

#### Release a transaction

Release an uncaptured transaction.

``` ruby
released = express_pay.release
released.transaction_id           # => "20160718111604002633"
released.status                   # => "success"
released.released                 # => true
released.release_transaction_id   # => "20160718111529002632" (id of the transaction that was released)
released.time                     # => 2017-01-18 12:08:42 +0900
```

#### Cancel a transaction

``` ruby
cancelled = express_pay.cancel
cancelled.transaction_id            # => "20160718111604002633"
cancelled.status                    # => "success"
cancelled.cancelled                 # => true
cancelled.cancel_transaction_id     # => "20160718111529002632" (id of the transaction that was cancelled)
cancelled.time                      # => 2017-01-18 12:08:42 +0900
```

Transactions can only be cancelled before the daily settlement deadline. Transactions cannot be cancelled if a partial or full refund on the transaction has already been issued.


## Working with transactions

#### List transactions

Only SecurePay, ExpressPay, and Captured transactions can be returned. For details on Released, Cancelled, and Refunded transactions, please navigate to the [TMS](https://tms.nihaopay.com). Transactions are returned with the most recent transactions appearing first.

``` ruby
transactions = Nihaopay::Transactions::Base.fetch
```

By default, only 10 transactions are returned at a time. This can be adjusted by calling `limit` before `fetch`. `limit` can range between 1 and 100.

``` ruby
transactions = Nihaopay::Transactions::Base.limit(5).fetch
```

To retrieve transactions that were processed after the specified time, you can all `after` with `Time` object.

``` ruby
yesterday = Time.now - 24 * 60 * 60
transactions = Nihaopay::Transactions::Base.after(yesterday).fetch
```

Similarly, you can fetch the transactions that were processed before the specified time.

``` ruby
yesterday = Time.now - 24 * 60 * 60
transactions = Nihaopay::Transactions::Base.before(yesterday).fetch
```

You can chain methods to use multiple options:

``` ruby
yesterday = Time.now - 24 * 60 * 60
week_ago = Time.now - 7 * 24 * 60 * 60
transactions = Nihaopay::Transactions::Base.before(yesterday)
                                           .after(week_ago)
                                           .limit(5).fetch
```

OR

you can pass the options to `fetch`:

``` ruby
yesterday = Time.now - 24 * 60 * 60
week_ago = Time.now - 7 * 24 * 60 * 60
transactions = Nihaopay::Transactions::Base.fetch(before: yesterday,
                                                  after: week_ago,
                                                  limit: 5)
```

#### Look up a transaction

Provide a unique transaction ID that was returned from a previous response in order to retrieve corresponding transaction’s details.

``` ruby
transaction = Nihaopay::Transactions::Base.find(transaction_id)
transaction.transaction_id  # => "20160718111604002633"
transaction.type            # => "charge"
transaction.status          # => "success"
```

Possible values of `transaction.type` are *"charge"*, *"authorization"*, or *"capture"*. You can also access `amount`, `currency`, `time`, `reference`, and `note` on above `transaction` object.

Only SecurePay (UnionPay and AliPay), ExpressPay, and Captured transaction details can be found. For details on Released, Cancelled, and Refunded transactions, please navigate to the [TMS](https://tms.nihaopay.com)

#### Refund a transaction

Full refunds can only be created once per transaction.

``` ruby
refunded = express_pay.refund
refunded.transaction_id            # => "20160718111604002633"
refunded.status                    # => "success"
refunded.refunded                  # => true
refunded.refund_transaction_id     # => "20160718111529002632" (id of the transaction that was refunded)
refunded.time                      # => 2017-01-18 12:08:42 +0900
```

You can pass a `reason` when refunding a transaction:

``` ruby
refunded = express_pay.refund(reason: 'Out of stock')
```

Partial refunds can be created multiple times up to the amount of the Transaction.

``` ruby
refunded = express_pay.partial_refund(amount)
refunded = express_pay.partial_refund(amount, reason: 'Cancellation fee')
```

#### Override global token

If you have multiple merchants configured to the Nihaopay payment gateway, they will have different tokens each. You can do transactions per merchant as below:

``` ruby
merchant_token = "6c4dc4828474fa73c5f438a9eb2fbf3092e44"
nihaopay_merchant = Nihaopay::Merchant.new(merchant_token)
express_pay = nihaopay_merchant.authorize(amount, credit_card)
```

OR

``` ruby
express_pay = nihaopay_merchant.authorize(amount, credit_card, options)
```

`options` may include `currency`, `description`, `reference`, `note`, and `merchant_id`.

Similarly, you can do other transactions directly on `Nihaopay::Merchant` object:

``` ruby
# capture
express_pay = nihaopay_merchant.capture(transaction_id, amount, currency)

# purchase
express_pay = nihaopay_merchant.purchase(amount, credit_card)
express_pay = nihaopay_merchant.purchase(amount, credit_card, options)

# release
express_pay = nihaopay_merchant.release(transaction_id)

#refund
express_pay = nihaopay_merchant.refund(transaction_id, amount, currency)
express_pay = nihaopay_merchant.refund(transaction_id, amount, currency, reason: 'Cancellation fee')
```


## License

This library is provided by [KK VESPER](https://www.kkvesper.jp/) under the MIT License. Refer to LICENSE for details.

NihaoPay is trademark of [Aurfy Inc](https://www.nihaopay.com). Aurfy Inc does not provide, support, or endorse this library.
