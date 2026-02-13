#!/usr/bin/sh
set -e;

cat > bin/rails << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

APP_PATH = File.expand_path("../config/application", __dir__)
require_relative "../config/boot"
require "rails/commands"
EOF

chmod +x bin/rails;

cat > bin/rake << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/boot"
require "rake"
Rake.application.run
EOF

chmod +x bin/rake;
