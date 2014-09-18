module Support
  module Helpers
    # Add some helpers
    def fixture_path(*args)
      File.join(SPEC_DIR, 'fixtures', args)
    end
  end
end
