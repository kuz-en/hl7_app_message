class MessageService
  Patient = Struct.new(:firstname, :middlename, :lastname, :birth_date, :sex, keyword_init: true)
  Request = Struct.new(:uid, :scheduled_at, :service_abbr, :dicom_id, :dicom_uid, keyword_init: true)
  Technician = Struct.new(:firstname, :middlename, :lastname, keyword_init: true)

  def initialize(patient = Patient.new(firstname: 'Александр',
                                       middlename: 'Михайлович',
                                       lastname: 'Тулузаков',
                                       birth_date: Date.new(1950, 1, 21),
                                       sex: 'm'),

                 request = Request.new(uid: '85792_smol',
                                       scheduled_at: DateTime.new(2019, 6, 21, 16, 5, 0),
                                       service_abbr: 'L-spine',
                                       dicom_id: 'SMK00445657_1',
                                       dicom_uid: '1.3.12.2.1107.5.2.6.24133.69992.2019062145261830715'),

                 technician = Technician.new(firstname: 'Людмила',
                                             middlename: 'Викторовна',
                                             lastname: 'Щербакова'))

    @patient = patient
    @request = request
    @technician = technician
  end

  def perform
    translit_name(@patient)
    translit_name(@technician)
    create_message
    broadcast_message
  end

  private

  def translit_name(person_data)
    person_data.each_pair do |key, value|
      person_data[key] = Russian.translit(value) if %i[firstname middlename lastname].include?(key)
    end
  end

  def create_message
    @message = SimpleHL7::Message.new(segment_separator: "\r\n")
    @message.msh[4][1] = 'MRTEXPERT'
    @message.msh[9][1][1] = 'ORM'
    @message.msh[9][2][1] = 'O01'
    @message.msh[11][1][1] = 'P'
    @message.msh[12][1][1] = '2.3'
    @message.msh[19][1] = ''

    @message.pid[5][1] = "#{@patient.lastname} #{@patient.firstname.first}#{@patient.middlename.first}".upcase
    @message.pid[7][1] = @patient.birth_date.strftime('%Y%m%d')
    @message.pid[3][1] = "#{@request.uid}"
    @message.pid[3][4][2] = 'MIAS'
    @message.pid[8][1] = "#{@patient.sex}".upcase
    @message.pid[10][1] = '0'
    @message.pid[16][1] = ''

    @message.orc[1] = 'NW'
    @message.orc[7][4] = @request.scheduled_at.strftime('%Y%m%d%H%M')
    @message.orc[13][1] = ''

    @message.obr[4][5] = @request.service_abbr
    @message.obr[18][1] = @technician.lastname
    @message.obr[19][1] = @request.dicom_id
    @message.obr[20][1] = @technician.lastname
    @message.obr[24][1] = 'MR'
    @message.obr[34][1][1] = 'True'
    @message.obr[34][1][2] = "#{@technician.lastname} #{@technician.firstname} #{@technician.middlename}"
    @message.obr[43][1] = ''

    @message.zds[1][1] = @request.dicom_uid
    @message.zds[2][1] = 'MRSI24133'
    @message.zds[3][1] = 'MRSI24133'

    @message.pv1[8][1] = 'True'
    @message.pv1[8][2] = ''
    @message.pv1[9][1] = 'True'
    @message.pv1[9][2] = ''
  end

  def broadcast_message
    socket = TCPSocket.open(ipaddr, port)
    socket.write @message.to_llp
    socket.close
  end
end
