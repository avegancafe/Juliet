(import-macros {: pack} :themis.pack.lazy)

(pack :RRethy/vim-illuminate
      {:config (fn []
                 (let [illuminate (require :illuminate)]
                   (illuminate.configure {:filetypes_denylist [:dashboard
                                                               :lspsagaoutline
                                                               :NvimTree]})))})
