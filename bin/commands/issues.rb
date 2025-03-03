# frozen_string_literal: true

desc 'Data on GitHub issues.'
command 'issue', 'issues' do |g|
  g.flag %i[page], desc: 'Size of page in days.', default_value: 7, type: Integer
  g.flag %i[from], desc: 'Start at.', default_value: Date.today.beginning_of_week.last_week
  g.flag %i[to], desc: 'End at.', default_value: Date.today.beginning_of_week - 1
  g.flag %i[o org], desc: 'Name of the GitHub organization.'
  g.flag %i[repo], multiple: true, desc: 'Search a specific repo within the org.'

  g.desc 'List issue stats in the organization.'
  g.command 'labels' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
      org.issues(options).labels.sort.each do |label, issues|
        puts "#{label}: #{issues.count}"
      end
    end
  end

  g.desc 'Find oldest untriaged offenders.'
  g.command 'untriaged' do |c|
    c.action do |_global_options, options, _args|
      org = GitHub::Organization.new(options.merge(org: options['org'] || 'opensearch-project'))
      untriaged_issues = org.issues(options.merge(label: 'untriaged'))
      puts "There are #{untriaged_issues.count} untriaged issues created between #{Chronic.parse(options[:from]).to_date} and #{Chronic.parse(options[:to]).to_date}, and #{untriaged_issues.created_before(Time.now - 3.months).count} issues older than 3 months."
      puts "\n# By Repo\n"
      untriaged_issues.repos.each_pair do |repo, issues|
        puts "#{repo}: #{issues.count}"
      end
      puts "\n# Oldest Issues\n"
      untriaged_issues.sort_by { |i| i.created_at }.take(25).each do |issue|
        puts "#{issue}, created #{DOTIW::Methods.distance_of_time_in_words(issue.created_at, Time.now, highest_measures: 1)} ago"
      end
    end
  end

  g.desc 'Find issues labelled for releases.'
  g.command 'released' do |c|
    c.action do |_global_options, options, _args|
      issues = GitHub::Issues.new(options)
      puts "# Label Counts\n"
      issues.version_labels.sort.each do |label, issues|
        puts "#{label}: #{issues.count}"
      end
      puts "\n# By Repo\n"
      issues.repos_version_labels.sort.each do |repo, version_labels|
        puts "#{repo.split('/').last}"
        version_labels.sort.each do |label, issues|
          puts "  #{label}: #{issues.count}"
        end
      end
    end
  end
end
