# # encoding: utf-8

# Inspec test for recipe nace_cometchat::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe port(80), :skip do
  it { should be_listening }
end
