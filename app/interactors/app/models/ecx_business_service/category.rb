# frozen_string_literal: true

class EcxBusinessService::Category < EcxBusinessService::ApplicationRecord
  has_one :parent, class_name: 'EcxBusinessService::Category'
  has_many :children, class_name: 'EcxBusinessService::Category', foreign_key: 'parent_id'
  has_many :tags
  has_many :profiles, through: :tags

  after_save :clear_cache
  after_create :clear_cache
  before_destroy :clear_cache

  scope :roots, -> { where(parent_id: nil) }

  def subtree
    if children.length > 0
      attributes.merge({ children: children.map { |c| c.subtree } })
    else
      attributes
    end
  end

  def selected_subtree(category_ids)
    if children.length > 0
      attributes.merge({ children: children.where(id: category_ids).map { |c| c.selected_subtree(category_ids) } })
    else
      attributes
    end
  end

  def clear_cache
    Rails.cache.delete_matched('business/categories_list*')
  end
end
