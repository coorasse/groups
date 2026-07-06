module Public
  # Le pagine pubbliche sono cookieless: non scrivono alcun cookie, così non
  # serve il cookie banner. Saltiamo la sessione (nessun cookie viene emesso) e,
  # dato che senza sessione la CSRF protection basata su token non è utilizzabile,
  # la sostituiamo con la verifica dell'header `Sec-Fetch-Site` (vedi
  # `verify_same_site_request`): accettiamo solo richieste same-origin / same-site.
  #
  # Questo replica ciò che Rails 8.2 farà nativamente con
  # `protect_from_forgery using: :header_only` (rails/rails#56350).
  # TODO(rails 8.2): rimuovere `skip_session` + `verify_same_site_request` e
  # sostituirli con `protect_from_forgery using: :header_only`.
  class BaseController < ApplicationController
    allow_unauthenticated_access
    layout "public"

    skip_forgery_protection
    before_action :skip_session

    private

    def skip_session
      request.session_options[:skip] = true
    end

    ALLOWED_FETCH_SITES = %w[same-origin same-site].freeze

    def verify_same_site_request
      return if ALLOWED_FETCH_SITES.include?(request.headers["Sec-Fetch-Site"])

      head :forbidden
    end
  end
end
