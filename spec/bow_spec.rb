# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bow do
  it 'has a version number' do
    expect(Bow::VERSION).not_to be nil
  end
end
