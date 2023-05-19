(import-macros {: pack} :macros)

(pack :RRethy/vim-illuminate
      {:config (fn []
                 (let [illuminate (require :illuminate)]
                   (illuminate.configure {:filetypes_denylist [:dashboard
                                                               :lspsagaoutline
                                                               :NvimTree]})))})
