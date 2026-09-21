# frozen_string_literal: true

class Sample
  def direct
    build(:direct)
  end

  def shared
    build(:shared)
  end

  private

  def build(name)
    name
  end
end
