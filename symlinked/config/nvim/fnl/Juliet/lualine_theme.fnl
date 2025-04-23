(local colors (require :bamboo.colors))
{:command {:a {:bg colors.yellow :fg colors.bg0 :gui :bold}
           :b {:bg colors.bg2 :fg colors.fg}
           :c {:bg colors.bg0 :fg colors.fg}
           :x {:bg colors.bg0 :fg colors.fg}
           :y {:bg colors.bg1 :fg colors.fg}
           :z {:bg colors.bg2 :fg colors.fg}}
 :inactive {:a {:bg colors.bg0 :fg colors.fg :gui :bold}
            :b {:bg colors.bg2 :fg colors.fg}
            :c {:bg colors.bg0 :fg colors.fg}
            :x {:bg colors.bg0 :fg colors.fg}
            :y {:bg colors.bg1 :fg colors.fg}
            :z {:bg colors.bg2 :fg colors.fg}}
 :insert {:a {:bg colors.blue :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :x {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg2 :fg colors.fg}}
 :normal {:a {:bg colors.green :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :x {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg2 :fg colors.fg}}
 :replace {:a {:bg colors.red :fg colors.bg0 :gui :bold}
           :b {:bg colors.bg1 :fg colors.fg}
           :c {:bg colors.bg0 :fg colors.fg}
           :x {:bg colors.bg0 :fg colors.fg}
           :y {:bg colors.bg1 :fg colors.fg}
           :z {:bg colors.bg2 :fg colors.fg}}
 :visual {:a {:bg colors.yellow :fg colors.bg0 :gui :bold}
          :b {:bg colors.bg1 :fg colors.fg}
          :c {:bg colors.bg0 :fg colors.fg}
          :x {:bg colors.bg0 :fg colors.fg}
          :y {:bg colors.bg1 :fg colors.fg}
          :z {:bg colors.bg2 :fg colors.fg}}}
