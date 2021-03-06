class Api::NotesController < ApplicationController

  def create
    @note = Note.new(note_params)

    if params[:note][:files]
      puts files
    end 
    
    if @note.save!
      if params[:note][:tags]
        tags = params.require(:note).permit(tags: {}).to_h[:tags]
        tag_names = tags.values.map {|tag| tag[:name]}
        tag_names.each do |name|
          tag = current_user.tags.find_by('lower(name) = ?', name.downcase) 
            unless tag 
              tag = Tag.new(name: name)
              tag.user_id = current_user.id
              tag.save
            end 
          Tagging.create(note_id: @note.id, tag_id: tag.id)
        end 
      end 
      render :show
    else 
      render json: @note.errors.full_messages, status: 422
    end 
  end 

  def index 
    page = params[:page].to_i
    limit = 25
    offset = (page - 1) * limit
    if params[:notebook_id] 
      @notes = current_user.notebooks
        .includes([:notes])
        .find(params[:notebook_id])
        .notes.includes([:notebook, :tags])
        .order(created_at: :desc)
        .limit(limit)
        .offset(offset)
      @note_count = current_user.notebooks.find(params[:notebook_id]).notes.count
    elsif params[:tag_id]
      @notes = current_user.tags
        .includes([:notes, :taggings])
        .find(params[:tag_id])
        .notes
        .includes([:notebook, :tags])
        .order(created_at: :desc)
        .limit(limit)
        .offset(offset)
      @note_count = current_user.tags.find(params[:tag_id]).notes.count
    elsif params[:shortcut] == 'true'
      limit = 50 
      offset = (page - 1) * limit
      if params[:search]
        @notes = current_user.notes
                             .where("lower(title) LIKE ? AND shortcut = 'true'", "%#{params[:search].downcase}%")
                             .order(created_at: :desc)
                             .limit(limit)
                             .offset(offset) 
        @note_count = current_user.notes
                                  .where("lower(title) LIKE ? AND shortcut = 'true'", "%#{params[:search].downcase}%")
                                  .count                             
      else                       
        @notes = current_user.notes
          .includes([:notebook, :tags])
          .where(shortcut: true)
          .order(created_at: :desc)        
          .limit(limit)
          .offset(offset)
        @note_count = current_user.notes.where(shortcut: true).count
      end  
    else 
      @notes = current_user.notes
        .includes([:notebook, :tags])
        .order(created_at: :desc)
        .limit(limit)
        .offset(offset)
      @note_count = current_user.notes.count
    end 
    render :index
  end 

  def show
    @note = current_user.notes.includes(:notebook).find(params[:id])

    if @note 
      render :show
    else 
      render json: ["This is not your note"], status: 404
    end 
  end 

  def update
    @note = current_user.notes.find(params[:id])
    if @note
      if params[:note][:shortcut] == 'true' 
        @note.shortcut = true
      elsif params[:note][:shortcut] == 'false'
        @note.shortcut = false
      end 
      if @note.update_attributes(note_params)
        render :show
      else 
        render json: @note.errors.full_messages, status: 422
      end 
    else 
      render json: ["Note does not exist"], status: 404
    end 
  end 

  def destroy
    @note = current_user.notes.find(params[:id])

    if @note 
      @note.destroy!
      render :show
    else 
      render json: ["Note does not exist"], status: 404
    end 
  end 

  private 

  def note_params
    params.require(:note).permit(:title, :body, :notebook_id, :shortcut)
  end
end
