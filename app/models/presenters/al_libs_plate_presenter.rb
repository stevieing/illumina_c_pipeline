module Presenters
  class AlLibsPlatePresenter < PlatePresenter
    include Presenters::Statemachine

    write_inheritable_attribute :authenticated_tab_states, {
      :pending     => [ 'labware-summary-button', 'labware-creation-button' ],
      :started     => [ 'labware-summary-button', 'labware-creation-button' ],
      :passed      => [ 'labware-summary-button', 'labware-creation-button', 'well-failing-button' ],
      :cancelled   => [ 'labware-summary-button' ],
      :failed      => [ 'labware-summary-button' ]
    }

    state_machine :state, :initial => :pending do
      Statemachine::StateTransitions.inject(self)

      state :pending do
        def control_additional_creation(&block)
          yield unless default_child_purpose.nil?
          nil
        end

        def default_child_purpose
          labware.plate_purpose.children.first
        end
      end

      state :started do
        def control_additional_creation(&block)
          yield unless default_child_purpose.nil?
          nil
        end

        def default_child_purpose
          labware.plate_purpose.children.first
        end
      end

      state :passed do
        # Yields to the block if there are child plates that can be created from the current one.
        # It passes the valid child plate purposes to the block.
        def control_additional_creation(&block)
          yield unless default_child_purpose.nil?
          nil
        end

        # Returns the child plate purposes that can be created in the passed state.
        def default_child_purpose
          labware.plate_purpose.children.last
        end
      end

      state :failed do
        include StateDoesNotAllowChildCreation
      end
      state :cancelled do
        include StateDoesNotAllowChildCreation
      end
    end

    def control_state_change
      # No state change
    end


  end
end
