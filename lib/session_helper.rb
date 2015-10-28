# coding: utf-8
require 'securerandom'

# Librairies pour l'application
module Helper
  # Module pour la gestion des sessions
  module Session
    module_function

    # Generate a unique session id for clients
    def generate_session_id
    	s = SecureRandom.hex 4
    	puts "New session id : #{s}"
    	{'sessionId' => s}.to_json 
    end
  end
end
