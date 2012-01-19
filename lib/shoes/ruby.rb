class Object
  include Types
  def include_swt
    include_package 'org.eclipse.swt'
    include_package 'org.eclipse.swt.layout'
    include_package 'org.eclipse.swt.widgets'
    include_package 'org.eclipse.swt.graphics'
  end
end
