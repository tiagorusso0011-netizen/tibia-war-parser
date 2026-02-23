import { 
  Controller, 
  Post, 
  UseInterceptors, 
  UploadedFile, 
  ParseFilePipe, 
  MaxFileSizeValidator, 
  HttpCode, 
  HttpStatus,
  BadRequestException 
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { WarParserService } from './war-parser.service';
import * as fs from 'fs';

// Garante que a pasta uploads existe para evitar erros de diretório
if (!fs.existsSync('./uploads')) {
  fs.mkdirSync('./uploads');
}

@Controller('api/v1/wars')
export class WarParserController {
  constructor(private readonly parserService: WarParserService) {}

  @Post('upload')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('server_log', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `combat-log-${uniqueSuffix}${extname(file.originalname)}`);
      }
    })
  }))
  async uploadWarLog(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 1024 * 1024 * 10 }) // Trava de segurança: 10MB
        ],
      }),
    ) file: Express.Multer.File,
  ) {
    // VALIDAÇÃO DE SEGURANÇA (TECH LEAD INSIGHT)
    // Lê o início do arquivo para garantir que é um log real antes de processar
    const fileContent = fs.readFileSync(file.path, 'utf8');
    const firstLine = fileContent.split('\n')[0];
    
    // Verifica se a primeira linha contém o padrão de data ou a palavra 'Match'
    const isValidLog = firstLine.includes('Match') || firstLine.match(/\d{2}\/\d{2}\/\d{4}/);

    if (!isValidLog) {
      // Se for um arquivo inválido, deleta imediatamente para não ocupar espaço
      if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
      throw new BadRequestException('O arquivo enviado não é um log válido do servidor Havera.');
    }

    // Se passar na validação, envia para o motor de processamento Ruby
    return this.parserService.processLogFile(file.path);
  }
}