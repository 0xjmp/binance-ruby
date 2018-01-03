# Binance::Api

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'binance-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install binance-ruby

## Setup

### Environment Variables

At minimum, you must configure the following environment variables:

```bash
BINANCE_API_KEY
BINANCE_SECRET_KEY
```

Additionally, Binance allows granular API key access based on the action being taken. For example, it is possible to use one API key for _only_ trade actions, while using another for withdrawal actions. You can configure this using any of the following keys:

```bash
BINANCE_READ_INFO_API_KEY
BINANCE_TRADING_API_KEY
BINANCE_WITHDRAWALS_API_KEY
```

If any one of these keys are not defined, `binance-ruby` will fallback to `BINANCE_API_KEY`.

## Usage

I highly recommend reading the [official Binance documentation](https://github.com/binance-exchange/binance-official-api-docs) before using this gem. Anything missed here is surely well explained there.

### Binance::Api

- `candlesticks!`: Kline/candlestick bars for a symbol. Klines are uniquely identified by their open time.
- `compressed_aggregate_trades!`: Get compressed, aggregate trades. Trades that fill at the time, from the same order, with the same price will have the quantity aggregated.
- `depth!`: Get your order book.
- `exchange_info!`: Current exchange trading rules and symbol information.
- `historical_trades!`: Get older trades.
- `ping!`: Test connectivity to the Rest API.
- `ticker!`: Price change statistics. **Careful** when accessing this with no symbol.
- `time!`: Test connectivity to the Rest API and get the current server time.
- `trades!`: Get recent trades (up to last 500).

### Binance::Api::Account

- `info!`: Get current account information.
- `trades!`: Get trades for a specific account and symbol.

### Binance::Api::DataStream

- `start!`: Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
- `keepalive!`: Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
- `stop!`: Close out a user data stream.

### Binance::Api::Order

- `all!`: Get all account orders; active, canceled, or filled.
- `all_open!`: Get all open orders on a symbol. **Careful** when accessing this with no symbol.
- `cancel!`: Cancel an active order.
- `create!`: Send in a new order. Use `test: true` for test orders.
- `status!`: Check an order's status.

For more information, please refer to the [official Rest API documentation](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md) written by the Binance team.

## Author

[Jake Peterson](https://jakenberg.io)

I drink beer 😉
**BTC**: `1EZTj5rEaKE9dEBjR1wiismwma4XpXtLBz`
**ETH**: `0xf61195dcb1e89f139114e599cf1dd37dd8b7b96a`
**LTC**: `LL3Nf7CmLoFeLENSKN6WhgPNVuxjzgh2eV`
**BCH**: Bcash. LOL

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jakenberg/binance-ruby.

### TODO
- Convert milliseconds to ruby DateTime.
- CodeCov account & badge.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
