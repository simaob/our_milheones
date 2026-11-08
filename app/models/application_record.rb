class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Adds `has_enumeration_for` (used by Transaction#kind)
  extend EnumerateIt
end
