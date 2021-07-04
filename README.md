# Binance::Api [![Gem Version](https://badge.fury.io/rb/binance-ruby.svg)](https://badge.fury.io/rb/binance-ruby) [![Circle CI](https://circleci.com/gh/Jakenberg/binance-ruby.svg?style=shield)](https://circleci.com/gh/Jakenberg/binance-ruby) [![codecov](https://codecov.io/gh/Jakenberg/binance-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/Jakenberg/binance-ruby) [![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJakenberg%2Fbinance-ruby.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FJakenberg%2Fbinance-ruby?ref=badge_shield)

## Features

- Spot & Margin Trading
- 100% test coverage (stable!)
- Exception handling
- Automatic timestamp and signature generation
- Support for United States (binance.us)

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

### API Keys

At minimum, you must configure the following environment variables:

```bash
BINANCE_API_KEY
BINANCE_SECRET_KEY
```

or as instance variables:

```ruby
Binance::Api::Configuration.api_key = nil
Binance::Api::Configuration.secret_key = nil
```

Additionally, Binance allows granular API key access based on the action being taken. For example, it is possible to use one API key for _only_ trade actions, while using another for withdrawal actions. You can configure this using any of the following keys:

```bash
BINANCE_READ_INFO_API_KEY
BINANCE_TRADING_API_KEY
BINANCE_WITHDRAWALS_API_KEY
```

or as instance variables:

```ruby
Binance::Api::Configuration.read_info_api_key = nil
Binance::Api::Configuration.trading_api_key = nil
Binance::Api::Configuration.withdrawals_api_key = nil
```

If any one of these keys are not defined, `binance-ruby` will fallback to `BINANCE_API_KEY`/`Binance::Api::Configuration.api_key`.


If you want to use binance test net to test the feature, you could configure the following environment variable:

```bash
BINANCE_TEST_NET_ENABLE=true
```

### Accounts in the USA

If your Binance account is based in the United States (www.binance.us), you will need to specify that in an environment variable:

```ruby
BINANCE_TLD = US
```

## Usage

### API Examples

```ruby
Binance::Api.ping!

Binance::Api::Order.create!(
  quantity: '100.0',
  side: 'BUY',
  symbol: 'XRPBTC',
  type: 'MARKET'
)
```

### WebSocket Examples

**Candlesticks:**

```ruby
# These callbacks are optional.
on_open = ->(event) do
  puts ">> Websocket opened"
end
on_close = ->(event) do
  puts ">> Websocket closed (#{event.code}): #{event.reason}"
end
EM.run do
  websocket = Binance::WebSocket.new(on_open: on_open, on_close: on_close)

  websocket.candlesticks!(['ETHBTC'], '1h') do |stream_name, kline_candlestick|
    symbol = kline_candlestick[:s]
    # Do whatever!
  end
end
```

**User Data:**

```ruby
EM.run do
  websocket = Binance::WebSocket.new

  # Be sure to call keepalive! roughly every 30 minutes
  listen_key = Binance::Api::UserDataStream.start!
  websocket.user_data_stream!(listen_key) do |listen_key, data|
    case data[:e].to_sym # event type
    when :outboundAccountPosition
      # Account update
    when :balanceUpdate
      # Balance update
    when :executionReport
      # Order update
    end
  end
end
```

You can find more info on all `kline_candlestick` attributes & available intervals in the [binance documentation](https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#klinecandlestick-streams).

### Binance::Api class methods

- [`candlesticks!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#klinecandlestick-data): Kline/candlestick bars for a symbol. Klines are uniquely identified by their open time.
- [`compressed_aggregate_trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#compressedaggregate-trades-list): Get compressed, aggregate trades. Trades that fill at the time, from the same order, with the same price will have the quantity aggregated.
- [`depth!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#order-book): Get your order book.
- [`exchange_info!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#exchange-information): Current exchange trading rules and symbol information.
- [`historical_trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#old-trade-lookup-market_data): Get older trades.
- [`ping!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#test-connectivity): Test connectivity to the Rest API.
- [`ticker!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#24hr-ticker-price-change-statistics): Price change statistics. **Careful** when accessing this with no symbol.
- [`time!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#check-server-time): Test connectivity to the Rest API and get the current server time.
- [`trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#recent-trades-list): Get recent trades (up to last 500).

### Binance::Api::Account class methods

- [`fees!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/wapi-api.md#asset-detail-user_data): Get withdrawal information (status, minimum amount and fees) for all symbols.
- [`info!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#account-information-user_data): Get current account information.
- [`trades!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#account-trade-list-user_data): Get trades for a specific account and symbol.
- [`withdraw!`](https://binance-docs.github.io/apidocs/spot/en/#withdraw-sapi): Submit a withdraw request. _I haven't confirmed this works for binance.us yet. If you find that it does, please submit a PR!_

### Binance::Api::DataStream class methods

- [`start!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#start-user-data-stream-user_stream): Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
- [`keepalive!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#keepalive-user-data-stream-user_stream): Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
- [`stop!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#close-user-data-stream-user_stream): Close out a user data stream.

### Binance::Api::Order class methods

- [`all!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#all-orders-user_data): Get all account orders; active, canceled, or filled.
- [`all_open!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#current-open-orders-user_data): Get all open orders on a symbol. **Careful** when accessing this with no symbol.
- [`cancel!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#cancel-order-trade): Cancel an active order.
- [`create!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#new-order--trade): Send in a new order. Use `test: true` for test orders.
- [`status!`](https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md#query-order-user_data): Check an order's status.

### Binance::Api::Margin::Order class methods

- [`create!`](https://binance-docs.github.io/apidocs/spot/en/#margin-account-new-order-trade): Create a new margin order.

### Binance::WebSocket instance methods

- [`candlesticks!`](https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#klinecandlestick-streams): Kline/candlestick bars for a symbol.
- [`user_data_stream!`](https://github.com/binance/binance-spot-api-docs/blob/master/user-data-stream.md#web-socket-payloads): account updates, balances changes, and order updates.

See the [rubydoc](http://www.rubydoc.info/gems/binance-ruby/0.1.2/Binance) for information about parameters for each method listed above.

For more information, please refer to the [official Rest API documentation](https://github.com/binance-exchange/binance-official-api-docs) written by the Binance team.

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

## Troubleshooting

### (-2015) Invalid API-key, IP, or permissions for action.

Are your API keys from a binance.us account? [How-to configure](https://github.com/jakenberg/binance-ruby#accounts-in-the-usa).

### "(-1021) Timestamp for this request was 1000ms ahead of the server's time."

The operational system clock is ahead/behind regarding the Binance's timestamp clock.

#### Resolution: Linux

Use the command: `sudo ntpdate time.nist.gov`.

If `ntpdate` is not installed: `sudo apt install ntpdate`.

#### Resolution: Windows

Use the path: Right-click on tray clock > Adjust date/time > Additional date, time & regional settings > Date and Time > Internet time > Change settings...

- Option "Syncronize with an Internet time server" should be enabled;
- "Server" should be "time.nist.org".

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jakenberg/binance-ruby.

### TODO

- DateTime parameters (in addition to milliseconds).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJakenberg%2Fbinance-ruby.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FJakenberg%2Fbinance-ruby?ref=badge_large)
