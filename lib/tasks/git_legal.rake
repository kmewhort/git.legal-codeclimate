namespace :git_legal do
  desc "Refresh source files coming from Git.legal"
  task :refresh_source => [:environment] do
    require 'fileutils'

    GIT_LEGAL_MAIN_PROJECT_ROOT = Rails.root.join('..','git.legal','app').to_s
    GIT_LEGAL_CC_ROOT = Rails.root.join('lib','git.legal').to_s

    Dir["#{GIT_LEGAL_CC_ROOT}/**/*"].each do |file|
      next unless File.file? file

      relative_path = file.to_s.gsub GIT_LEGAL_CC_ROOT, ''
      main_project_path = "#{GIT_LEGAL_MAIN_PROJECT_ROOT}#{relative_path}"

      puts "Copying #{main_project_path}..."
      FileUtils.cp main_project_path, file
    end
  end

  task :refresh_db, [:from_db, :to_db] => [:environment] do |task, args|
    source_db = args[:from_db] or raise 'Please specify the source and target databases'
    target_db = args[:to_db] or raise 'Please specify the source and target databases'

    # for copying from a cached copy to the new db
    def restore_objects(objs, source_db, target_db)
      return if objs.blank?
      objs = objs.to_a
      model = objs.first.class

      # flip to new db
      ActiveRecord::Base.establish_connection target_db

      # delete any existing objects
      objs.first.class.delete_all

      total = objs.count
      puts "Loading #{objs.first.class.to_s} table..."

      i = 1
      objs.map {|old_object|
        puts "#{i} of #{total}" if i % 1000 == 0

        old_attrs = old_object.attributes.reject {|a| a == 'id'}

        new_object = model.new
        new_object.send :attributes=, old_attrs
        new_object.id = old_object.id

        new_object.save!(validate: false)

        i += 1
      }

      # flip back to the old db
      ActiveRecord::Base.establish_connection source_db
    end

    ActiveRecord::Base.establish_connection source_db

    projects = Project.where(system: true)
    restore_objects projects, source_db, target_db

    restore_objects Policy.where(project_id: projects.pluck(:id)), source_db, target_db

    branches = Branch.where(project_id: projects.pluck(:id))
    restore_objects branches, source_db, target_db

    libraries = Library.where(branch_id: branches.pluck(:id))
    restore_objects libraries, source_db, target_db

    licenses = libraries.map {|l| l.licenses}.flatten
    # only pull license types tied to the licenses we pull in
    license_type_ids = licenses.map {|l| l.license_type_id}.uniq

    LicenseType.skip_callback :save, :before, :generate_searchable_identifiers
    restore_objects LicenseType.where(id: license_type_ids), source_db, target_db
    restore_objects Obligation.where(license_type_id: license_type_ids), source_db, target_db
    restore_objects CopyleftClause.where(license_type_id: license_type_ids), source_db, target_db

    restore_objects licenses, source_db, target_db
  end
end
