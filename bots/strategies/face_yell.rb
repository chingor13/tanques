module Strategies
  module FaceYell
    def face_yell!
      if target
        if sensors.ticks % 60
          all = true
          fetch_all(:target_distance).each{|dist| all &&= (dist && dist < 100)}
          log "GET OUT OF MY FACE #{target.name}!!!!!!!" if all
        end
      end
    end
  end
end