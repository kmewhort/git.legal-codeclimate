class AddAllowUnknownLibrariesToPolicy < ActiveRecord::Migration
  def change
    add_column :policies, :allow_unknown_libraries, :boolean, default: false
  end
end
