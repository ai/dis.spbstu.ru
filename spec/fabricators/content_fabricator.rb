Fabricator(:content) do
  path { sequence(:path) { |i| "/path/to/#{i}" } }
  text 'First text'
end

Fabricator(:deleted_content, from: :content) do
  deleted_at Time.now
end
