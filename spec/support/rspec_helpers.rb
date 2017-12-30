module RSpecHelpers
  def file_fixture(path)
    File.read(File.join('spec', 'fixtures', path))
  end

  def is_expected_block
    expect { subject }
  end

  def json_fixture(fixture_name)
    file_fixture("#{fixture_name}.json")
  end
end
