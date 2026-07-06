require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  it "connects with a valid session cookie" do
    session = create(:sys_manager).sessions.create!
    cookies.signed[:session_id] = session.id

    connect "/cable"

    expect(connection.current_sys_manager).to eq(session.sys_manager)
  end

  it "rejects an unauthenticated connection" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end
