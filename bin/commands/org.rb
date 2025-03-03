# frozen_string_literal: true

desc 'Data about a GitHub organization.'
command 'org' do |g|
  g.flag %i[o org], desc: 'Name of the GitHub organization.', default_value: 'opensearch-project'

  g.desc 'Show information about a GitHub organization.'
  g.command 'info' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      puts org.info
    end
  end

  g.desc 'Compare GitHub org members to lists of members in data files.'
  g.command 'members' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      puts "org: #{org.name}"
      puts "members: #{org.members.count}"
      puts "missing in data/users/members.txt: #{(org.members.logins - GitHub::Data.members).join(' ')}"
      puts "no longer members: #{(GitHub::Data.members - org.members.logins).join(' ')}"
    end
  end

  g.desc 'Audit teams.'
  g.command 'teams' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options)
      puts "org: #{org.name}"
      puts "teams: #{org.teams.count}"
      org.teams.sort_by(&:name).each do |team|
        puts "#{team.name}\t#{team.description}\t#{team.repos.count}"
      end
    end
  end
end
