(import-macros {: pack} :Juliet.macros)

(pack :RRethy/vim-illuminate
      {:config (fn []
                 (let [illuminate (require :illuminate)]
                   (illuminate.configure {:filetypes_denylist [:alpha
                                                               :lspsagaoutline
                                                               :minifiles]})))})
