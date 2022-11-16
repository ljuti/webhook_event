key = "e13aca438075c637003a11031f93861a73aea50c8520fd45af70c28f55348930da4274d3965462bbcf81b6e08f4eeb03cdda627a59379cd7ab15a2cbe6648ce2"

if Dummy::Application.config.respond_to? :secret_key_base=
  Dummy::Application.config.secret_key_base = key
else
  Dummy::Application.config.secret_token = key
end
