# TODO Rails 3.2.22.3 introduced a change that makes this required.
# When upgrading Rails, see if this is still required.
class ActionView::Helpers::InstanceTag
  include ActionView::Helpers::OutputSafetyHelper
end
