module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_sys_manager

    def connect
      set_current_sys_manager || reject_unauthorized_connection
    end

    private
      def set_current_sys_manager
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_sys_manager = session.sys_manager
        end
      end
  end
end
