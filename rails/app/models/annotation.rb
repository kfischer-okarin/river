class Annotation < ApplicationRecord
  class Gateway
    def self.create(youtube_id:, payload:)
      Annotation.create(video: Video.find_by(youtube_id: youtube_id), payload: payload).as_entity
    end

    def self.get(id)
      Annotation.find(id).as_entity
    end

    def self.get_all_annotations(youtube_id:, published_only: false)
      result = Annotation.joins(:video).where(videos: { youtube_id: youtube_id })
      result = result.where.not(position: nil) if published_only
      result.map(&:as_entity)
    end

    def self.publish(annotation_id:, position:)
      Annotation.find(annotation_id).tap { |published|
        published.update(position: position)
      }.as_entity
    end

    def self.delete(annotation_id)
      Annotation.find(annotation_id).destroy
    end
  end

  belongs_to :video

  serialize :payload, JSON

  def as_entity
    Jordan::Entities::Annotation.new(id: id, youtube_id: video.youtube_id, position: position, payload: payload)
  end
end