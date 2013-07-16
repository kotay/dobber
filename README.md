## Dobber

Lightweight interactions with [Dead Man's Snitch](https://deadmanssnitch.com)

##Usage

Dobbing of death:
```ruby
Dobber.dob(ENV["token"])
```

Dob status (status of a snitch, including list of healthy and failed snitches):
```ruby
Dobber.dobbings(ENV["email"], ENV["password"], ENV["snitch_id"])
```

## Copyright

See LICENSE for details.
