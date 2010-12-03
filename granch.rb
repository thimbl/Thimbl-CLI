require 'rubygems'
require 'grancher'
grancher = Grancher.new do |g|
  g.branch = 'gh-pages'         # alternatively, g.refspec = 'ghpages:/refs/heads/ghpages'
  g.push_to = 'origin'
  #g.repo = 'some_repo'          # defaults to '.'
  g.message = 'Updated website' # defaults to 'Updated files.'

  # Put the website-directory in the root
  g.directory 'website'

  # doc -> doc
  #g.directory 'doc', 'doc'

  # README -> README
  g.file 'README'

  # AUTHORS -> authors.txt
  #g.file 'AUTHORS', 'authors.txt'

  # CHANGELOG -> doc/CHANGELOG
  #g.file 'CHANGELOG', 'doc/'
end

grancher.commit
grancher.push
