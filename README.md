# AffectedTests

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/affected_tests`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add affected_tests

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install affected_tests

## Usage

### Aggregate data

#### on RSpec

on `spec/spec_helper.rb`:

```ruby
require "affected_tests"
require "affected_tests/rspec"

AffectedTests.setup(
  engine: :rotoscope,
  project_path: File.expand_path("../../", __FILE__),
  test_dir_path: "spec/",
  output_path: "log/affected-tests-map.json",
  revision: "1cf22fdb86e2b2d6107" # or git rev-parse HEAD > REVISION
)
```

this will write associated test files per file on `log/affected-tests-map.json`:

```json
{
  "revision": "1cf22fdb86e2b2d6107",
  "map": {
    "app/controllers/comments_controller.rb": [
      "spec/requests/comments_spec.rb"
    ],
    "app/views/comments/index.html.erb": [
      "spec/requests/comments_spec.rb",
      "spec/views/comments/index.html.erb_spec.rb"
    ]
  }
}
```

### Get Diff

#### Schema

```json
[
  { "filename": "app/models/post.rb", "status": "modified" },
  { "filename": "app/models/comment.rb", "status": "added" },
  { "filename": "app/helpers/something.rb", "status": "deleted" }
]
```

#### From GitHub

```ruby
client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

targets = client.compare(repository, base_sha, target_sha).files.map do |info|
  {
    filename: info.filename,
    status: info.status
  }
end
```

See also: `scripts/generate-diff-files-from-github`

### Calculate affected tests

```ruby
require "affected_tests/differ"

target_tests = AffectedTests::Differ.run(
  diff_file_path: "diff-files.json",
  map_file_path: "affected-tests-map.json"
)

pp target_tests
# => ["spec/models/post_spec.rb", "spec/requests/posts_spec.rb"]
```

See also: `scripts/calculate-target-tests`

#### Merge results from parallel test

```
require "affected_tests/map_merger"

AffectedTests::MapMerger.run(
  map_file_paths: %w[node1-result.json node2-result.json node3-result.json],
  output_path: "merged-result.json"
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/riseshia/affected_tests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/riseshia/affected_tests/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AffectedTests project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/riseshia/affected_tests/blob/main/CODE_OF_CONDUCT.md).
