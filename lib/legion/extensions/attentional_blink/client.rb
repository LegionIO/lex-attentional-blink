# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionalBlink
      class Client
        include Runners::AttentionalBlink

        def engine
          @engine ||= Helpers::BlinkEngine.new
        end
      end
    end
  end
end
