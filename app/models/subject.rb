class Subject < ApplicationRecord
  POST_ATTRS = %i(course_id name description start_time length).freeze

  belongs_to :course
  has_many :tasks, dependent: :destroy
  has_many :statuses, as: :finishable, dependent: :destroy

  validates :name, presence: true,
            length: {maximum: Settings.subject.name.max_length}
  validates :length,
            numericality: {only_integer: true, greater_than_or_equal_to:
                          Settings.subject.length.min}
  validates :start_time, presence: true
  validate :must_start_after_course_start_time
  scope :newest_subject, ->{order(created_at: :desc)}

  def must_start_after_course_start_time
    return unless start_time && course

    check = start_time < course.start_time
    return unless check

    errors.add(:start_time,
               :after_course_start_time,
               message: I18n.t("subjects.error.must_start_after_course"))
  end
end
