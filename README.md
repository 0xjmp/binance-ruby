# Binance::Api [![Circle CI](https://circleci.com/gh/Jakenberg/binance-ruby.svg?style=shield)](https://circleci.com/gh/Jakenberg/binance-ruby) [![codecov](https://codecov.io/gh/Jakenberg/binance-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/Jakenberg/binance-ruby)

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

- [`candlesticks!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#klinecandlestick-data): Kline/candlestick bars for a symbol. Klines are uniquely identified by their open time.
- [`compressed_aggregate_trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#compressedaggregate-trades-list): Get compressed, aggregate trades. Trades that fill at the time, from the same order, with the same price will have the quantity aggregated.
- [`depth!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#order-book): Get your order book.
- [`exchange_info!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#exchange-information): Current exchange trading rules and symbol information.
- [`historical_trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#old-trade-lookup-market_data): Get older trades.
- [`ping!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#test-connectivity): Test connectivity to the Rest API.
- [`ticker!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#24hr-ticker-price-change-statistics): Price change statistics. **Careful** when accessing this with no symbol.
- [`time!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#check-server-time): Test connectivity to the Rest API and get the current server time.
- [`trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#recent-trades-list): Get recent trades (up to last 500).

### Binance::Api::Account

- [`info!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#account-information-user_data): Get current account information.
- [`trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#account-trade-list-user_data): Get trades for a specific account and symbol.

### Binance::Api::DataStream

- [`start!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#start-user-data-stream-user_stream): Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
- [`keepalive!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#keepalive-user-data-stream-user_stream): Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
- [`stop!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#close-user-data-stream-user_stream): Close out a user data stream.

### Binance::Api::Order

- [`all!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#all-orders-user_data): Get all account orders; active, canceled, or filled.
- [`all_open!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#current-open-orders-user_data): Get all open orders on a symbol. **Careful** when accessing this with no symbol.
- [`cancel!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#cancel-order-trade): Cancel an active order.
- [`create!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#new-order--trade): Send in a new order. Use `test: true` for test orders.
- [`status!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#query-order-user_data): Check an order's status.

For more information, please refer to the [official Rest API documentation](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md) written by the Binance team.

## Author

[Jake Peterson](https://jakenberg.io)

I drink beer 😉

**BTC**: `1EZTj5rEaKE9dEBjR1wiismwma4XpXtLBz`

**ETH**: `0xf61195dcb1e89f139114e599cf1dd37dd8b7b96a`

**LTC**: `LL3Nf7CmLoFeLENSKN6WhgPNVuxjzgh2eV`

**BCH**: [Bcash. LOL](https://www.youtube.com/watch?v=oCOjCEth6xI)

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
