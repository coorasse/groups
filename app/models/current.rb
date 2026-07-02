class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :sys_manager, to: :session, allow_nil: true
end
