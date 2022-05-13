class Incident < ApplicationRecord
  def status
    !!resolved_at ? "resolved" : "open"
  end
end
