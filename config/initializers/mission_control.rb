# Mission Control inherits from ::ApplicationController (its default base controller),
# so access is already gated by the app's session authentication. Turn off its own
# extra HTTP basic auth layer, which would otherwise lock the dashboard out.
MissionControl::Jobs.http_basic_auth_enabled = false
